"use client";

import React from 'react';
import { Box, Typography, IconButton } from '@mui/material';
import { Add as AddIcon } from '@mui/icons-material';

interface TaskCounterProps {
  count: number;
  onIncrement: () => void;
}

export const TaskCounter: React.FC<TaskCounterProps> = ({ count, onIncrement }) => {
  return (
  <Box sx={{ display: 'flex', alignItems: 'center', borderRadius: 5, padding: 1, backgroundColor: 'grey' }}>     
   <Typography variant="body2">
        {count}/15
      </Typography>
      <IconButton 
        edge="end" 
        onClick={onIncrement}
        disabled={count >= 15}
      >
        <AddIcon />
      </IconButton>
    </Box>
  );
};